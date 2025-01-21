import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { type CompletedChore, type Chore, type User } from "@prisma/client";
import { TRPCError } from "@trpc/server";
import { z } from "zod";

export interface DueChore {
  description: string;
  dueDate: Date;
  assignedTo: User;
  completedBy: User | null;
  completionDate: Date | null;
}

export async function genDueChores(
  from: Date,
  to: Date,
  chores: Chore[],
  usersInCollective: User[],
  getCompletedChoreCallback: (
    choreId: string,
    choreWasDueAt: Date,
  ) => Promise<(CompletedChore & { completedByUser: User }) | null>,
): Promise<DueChore[]> {
  const UNIX_EPOCH_DAY = 1000 * 60 * 60 * 24;

  // Sort users by id to ensure consistent assignment order and workload for each user
  const assignees = usersInCollective.sort((a, b) => a.id.localeCompare(b.id));

  const dueChores: DueChore[] = [];

  // Iterate over all chores and assign them to users
  for (const chore of chores) {
    const frequency = chore.frequency * UNIX_EPOCH_DAY;

    // Start with the first user in the list at the original starting date
    let assigneeCounter =
      (chore.startingDate.valueOf() - from.valueOf()) / frequency;

    // Skip forward to the first due date after the 'from' date
    chore.startingDate = new Date(
      chore.startingDate.valueOf() +
        frequency *
          Math.ceil(
            (from.valueOf() - chore.startingDate.valueOf()) / frequency,
          ),
    );

    // While we are still inside the query range
    while (chore.startingDate <= to) {
      // Get the next assignee
      const assignee = assignees[assigneeCounter % assignees.length]!;

      const completedChore = await getCompletedChoreCallback(
        chore.id,
        chore.startingDate,
      );

      const completionDate = completedChore?.completedAt ?? null;
      const completedBy = completedChore?.completedByUser ?? null;

      // Add the chore to the list of due chores
      dueChores.push({
        description: chore.description,
        dueDate: chore.startingDate,
        assignedTo: assignee,
        completedBy: completedBy,
        completionDate: completionDate,
      });

      // Go to the next assignee
      assigneeCounter++;

      // Move the chore to the next due date
      chore.startingDate = new Date(chore.startingDate.valueOf() + frequency);
    }
  }

  // Sort due chores by due date
  dueChores.sort((a, b) => a.dueDate.valueOf() - b.dueDate.valueOf());

  return dueChores;
}

export const choreRouter = createTRPCRouter({
  getChores: collectiveProcedure.query(async ({ ctx }) => {
    return await ctx.db.chore.findMany({
      where: {
        collectiveId: ctx.session.user.collectiveId,
      },
    });
  }),
  getDueChores: collectiveProcedure
    .input(
      z.object({
        from: z.date(),
        to: z.date(),
      }),
    )
    .query(async ({ ctx, input: { from, to } }) => {
      if (to < from) {
        throw new TRPCError({
          code: "BAD_REQUEST",
          message:
            "Invalid date range: " +
            from.toISOString() +
            " -> " +
            to.toISOString() +
            ". 'to' date must be after 'from' date.",
        });
      }

      const chores = await ctx.db.chore.findMany({
        where: {
          collectiveId: ctx.session.user.collectiveId,
        },
      });

      const assignees = await ctx.db.user.findMany({
        where: {
          collectiveId: ctx.session.user.collectiveId,
        },
      });

      return await genDueChores(
        from,
        to,
        chores,
        assignees,
        async (choreId, choreWasDueAt) => {
          return await ctx.db.completedChore.findFirst({
            where: {
              choreId: choreId,
              choreWasDueAt: choreWasDueAt,
              completedByUserId: {
                in: assignees.map((user) => user.id),
              },
            },
            include: {
              completedByUser: true,
            },
          });
        },
      );
    }),
  createChore: collectiveProcedure
    .input(
      z.object({
        description: z.string().nonempty(),
        frequency: z.number().nonnegative().min(1),
        startingDate: z.date(),
      }),
    )
    .mutation(
      async ({ ctx, input: { description, frequency, startingDate } }) => {
        await ctx.db.chore.create({
          data: {
            description: description,
            frequency: frequency,
            collectiveId: ctx.session.user.collectiveId,
            startingDate: new Date(
              new Date().setFullYear(
                startingDate.getFullYear(),
                startingDate.getMonth(),
                startingDate.getDate(),
              ),
            ),
          },
        });
      },
    ),
  modifyChore: collectiveProcedure
    .input(
      z.object({
        choreId: z.string(),
        name: z.string().optional(),
        frequency: z.number().nonnegative().min(1).optional(),
        startingDate: z.date().optional(),
      }),
    )
    .mutation(
      async ({
        ctx,
        input: { choreId: choreId, name, frequency, startingDate },
      }) => {
        const chore = await ctx.db.chore.findUnique({
          where: {
            id: choreId,
          },
        });

        // Check vilidity and permissions
        if (!chore) {
          throw new TRPCError({
            code: "NOT_FOUND",
            message: "Chore not found",
          });
        } else if (chore.collectiveId !== ctx.session.user.collectiveId) {
          throw new TRPCError({
            code: "FORBIDDEN",
            message: "Chore does not belong to the user's collective",
          });
        }

        const updateData: {
          name?: string;
          frequency?: number;
          startingDate?: Date;
        } = {};

        if (name !== undefined) updateData.name = name;
        if (frequency !== undefined) updateData.frequency = frequency;
        if (startingDate !== undefined) updateData.startingDate = startingDate;

        // If the frequency is changed, remove all completed chores
        if (frequency !== undefined) {
          await ctx.db.completedChore.deleteMany({
            where: {
              choreId: choreId,
            },
          });
          // If the starting date is changed, shift all completed chores instead
        } else if (startingDate !== undefined) {
          // Shift completed chores by the difference in the starting date
          const chore = await ctx.db.chore.findUnique({
            where: {
              id: choreId,
            },
          });

          if (chore === null) {
            throw new TRPCError({
              code: "BAD_REQUEST",
              message: "Chore was not found",
            });
          }

          const shiftAmount =
            chore.startingDate.getTime() - startingDate.getTime();

          // Update the completed chores by adding shiftAmount
          await ctx.db.$queryRaw`
          UPDATE "CompletedChore"
          SET "completedAt" = "completedAt" + ${shiftAmount}
          WHERE "choreId" = ${choreId}
        `;
        }

        await ctx.db.chore.update({
          data: updateData,
          where: {
            id: choreId,
          },
        });
      },
    ),
  removeChore: collectiveProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: choreId }) => {
      try {
        await ctx.db.chore.delete({
          where: {
            id: choreId,
            collectiveId: ctx.session.user.collectiveId,
          },
        });
      } catch (e) {
        console.error(e);
        throw new TRPCError({
          code: "BAD_REQUEST",
          message:
            "Chore was not found or does not belong to the user's collective",
        });
      }
    }),
  completeChore: collectiveProcedure
    .input(
      z.object({
        choreId: z.string(),
        choreDueDate: z.date(),
      }),
    )
    .mutation(async ({ ctx, input: { choreDueDate, choreId } }) => {
      const chore = await ctx.db.chore.findUnique({
        where: {
          id: choreId,
          collectiveId: ctx.session.user.collectiveId,
        },
      });

      if (chore === null) {
        throw new TRPCError({
          code: "BAD_REQUEST",
          message: "Chore was not found",
        });
      }

      await ctx.db.completedChore.create({
        data: {
          choreId: choreId,
          choreWasDueAt: choreDueDate,
          completedAt: new Date(new Date().setHours(0, 0, 0, 0)),
          completedByUserId: ctx.session.user.id,
        },
      });
    }),
});
