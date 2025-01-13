import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { z } from "zod";

export const shoppingListRouter = createTRPCRouter({
  addItemToShoppingList: collectiveProcedure
    .input(z.string().nonempty())
    .mutation(async ({ ctx, input: item }) => {
      await ctx.db.shoppingListItem.create({
        data: {
          item: item,
          collectiveId: ctx.session.user.collectiveId,
          isBought: false,
          createdById: ctx.session.user.id,
        },
      });
    }),
  getShoppingList: collectiveProcedure.query(async ({ ctx }) => {
    return await ctx.db.shoppingListItem.findMany({
      where: {
        collectiveId: ctx.session.user.collectiveId,
      },
    });
  }),
  removeItemFromShoppingList: collectiveProcedure
    .input(z.string().nonempty())
    .mutation(async ({ ctx, input: itemId }) => {
      await ctx.db.shoppingListItem.delete({
        where: {
          collectiveId_item: {
            collectiveId: ctx.session.user.collectiveId,
            item: itemId,
          },
        },
      });
    }),
  toggleItemBoughtState: collectiveProcedure
    .input(z.string().nonempty())
    .mutation(async ({ ctx, input: item }) => {
      await ctx.db.$transaction(async (db) => {
        const itemToToggle = await db.shoppingListItem.findUnique({
          where: {
            collectiveId_item: {
              collectiveId: ctx.session.user.collectiveId,
              item: item,
            },
          },
        });

        if (!itemToToggle) {
          throw new Error("Item not found in shopping list");
        }

        await db.shoppingListItem.update({
          data: {
            isBought: !itemToToggle.isBought,
          },
          where: {
            collectiveId_item: {
              collectiveId: ctx.session.user.collectiveId,
              item: item,
            },
          },
        });
      });
    }),
  editItem: collectiveProcedure
    .input(
      z.object({
        oldName: z.string().nonempty(),
        newName: z.string().nonempty(),
      }),
    )
    .mutation(async ({ ctx, input: { oldName, newName } }) => {
      await ctx.db.shoppingListItem.update({
        data: {
          item: newName,
        },
        where: {
          collectiveId_item: {
            collectiveId: ctx.session.user.collectiveId,
            item: oldName,
          },
        },
      });
    }),
});
