import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { z } from "zod";

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
    .output(
      z
        .object({
          description: z.string(),
          dueDate: z.date(),
          user: z.object({
            name: z.string(),
            image: z.string(),
            id: z.string(),
          }),
          isCompleted: z.boolean(),
        })
        .array(),
    )
    .query(async ({ ctx, input: { from, to } }) => {
      if (to < from) {
        throw new Error(
          "Invalid date range: " +
            from.toISOString() +
            " -> " +
            to.toISOString() +
            ". 'to' date must be after 'from' date.",
        );
      }

      const chores = await ctx.db.chore.findMany({
        where: {
          collectiveId: ctx.session.user.collectiveId,
        },
      });

      const dueChores: {
        description: string;
        dueDate: Date;
        user: { name: string; image: string; id: string };
        isCompleted: boolean;
      }[] = [];

      // Get all users in the collective
      const usersInCollective = (
        await ctx.db.user.findMany({
          where: {
            collectiveId: ctx.session.user.collectiveId,
          },
        })
      ).map((user) => ({
        name: user.name ?? "Unknown",
        image: user.image ?? "",
        id: user.id,
      }));

      // If there are no users in the collective, we can't assign chores (if this throws, there is something seriously wrong)
      if (usersInCollective.length === 0) {
        throw new Error("No users in collective");
      }

      // Sort users by name to ensure consistent assignment order and workload for each user
      const assignees = usersInCollective.sort((a, b) =>
        a.name.localeCompare(b.name),
      );

      // Iterate over all chores and assign them to users
      for (const chore of chores) {
        // Start with the first user in the list at the original starting date
        let assigneeCounter =
          (chore.startingDate.getTime() - from.getTime()) / chore.frequency;

        // Skip forward to the first due date after the 'from' date
        chore.startingDate = new Date(
          ((from.getTime() - chore.startingDate.getTime()) % chore.frequency) +
            chore.frequency,
        );

        // While we are still inside the query range
        while (chore.startingDate <= to) {
          // Get the next assignee
          const assignee = assignees[assigneeCounter % assignees.length]!;

          // Add the chore to the list of due chores
          dueChores.push({
            description: chore.description,
            dueDate: chore.startingDate,
            user: assignee,
            isCompleted: await ctx.db.completedChore
              .findFirst({
                where: {
                  choreId: chore.id,
                  completedAt: chore.startingDate,
                  chore: {
                    collectiveId: ctx.session.user.collectiveId,
                  },
                },
              })
              .then((completedChore) => completedChore !== null),
          });

          // Go to the next assignee
          assigneeCounter++;

          // Move the chore to the next due date
          chore.startingDate = new Date(
            chore.startingDate.getTime() + chore.frequency,
          );
        }
      }

      // Sort due chores by due date
      dueChores.sort((a, b) => a.dueDate.getTime() - b.dueDate.getTime());

      return dueChores;
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
            startingDate: startingDate,
          },
        });
      },
    ),
  modifyChore: collectiveProcedure
    .input(
      z.object({
        id: z.string(),
        name: z.string().optional(),
        frequency: z.number().nonnegative().min(1).optional(),
        startingDate: z.date().optional(),
      }),
    )
    .mutation(async ({ ctx, input: { id, name, frequency, startingDate } }) => {
      const updateData: {
        name?: string;
        frequency?: number;
        startingDate?: Date;
      } = {};

      if (name !== undefined) updateData.name = name;
      if (frequency !== undefined) updateData.frequency = frequency;
      if (startingDate !== undefined) updateData.startingDate = startingDate;

      await ctx.db.completedChore.deleteMany({
        where: {
          choreId: id,
        },
      });

      await ctx.db.chore.update({
        data: updateData,
        where: {
          id: id,
        },
      });
    }),
  removeChore: collectiveProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: choreId }) => {
      await ctx.db.chore.delete({
        where: {
          id: choreId,
        },
      });
    }),
});
