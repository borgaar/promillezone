import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { z } from "zod";

export const shoppingListRouter = createTRPCRouter({
  createShoppingList: collectiveProcedure
    .input(z.string().nonempty())
    .mutation(async ({ ctx, input: name }) => {
      await ctx.db.shoppingList.create({
        data: {
          name: name,
          owner: ctx.session.user.collectiveId,
        },
      });
    }),
  editShoppingList: collectiveProcedure
    .input(
      z.object({
        shoppingListId: z.string().nonempty(),
        name: z.string().nonempty(),
      }),
    )
    .mutation(async ({ ctx, input: { shoppingListId, name } }) => {
      await ctx.db.shoppingList.update({
        data: {
          name: name,
        },
        where: {
          id: shoppingListId,
        },
      });
    }),
  deleteShoppingList: collectiveProcedure
    .input(z.string().nonempty())
    .mutation(async ({ ctx, input: id }) => {
      await ctx.db.shoppingList.delete({
        where: {
          id: id,
        },
      });
    }),
  addItemToShoppingList: collectiveProcedure
    .input(
      z.object({
        shoppingListId: z.string().nonempty(),
        item: z.string().nonempty(),
      }),
    )
    .mutation(async ({ ctx, input: { shoppingListId, item } }) => {
      await ctx.db.shoppingListItem.create({
        data: {
          item: item,
          shoppingListId: shoppingListId,
          isBought: false,
        },
      });
    }),
  removeItemFromShoppingList: collectiveProcedure
    .input(
      z.object({
        shoppingListId: z.string().nonempty(),
        itemId: z.string().nonempty(),
      }),
    )
    .mutation(async ({ ctx, input: { shoppingListId, itemId: item } }) => {
      await ctx.db.shoppingListItem.delete({
        where: {
          shoppingListId_item: {
            shoppingListId: shoppingListId,
            item: item,
          },
        },
      });
    }),
  toggleItemBoughtState: collectiveProcedure
    .input(
      z.object({
        shoppingListId: z.string().nonempty(),
        item: z.string().nonempty(),
      }),
    )
    .mutation(async ({ ctx, input: { shoppingListId, item: item } }) => {
      await ctx.db.$transaction(async (db) => {
        const itemToToggle = await db.shoppingListItem.findUnique({
          where: {
            shoppingListId_item: {
              shoppingListId: shoppingListId,
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
            shoppingListId_item: {
              shoppingListId: shoppingListId,
              item: itemToToggle.item,
            },
          },
        });
      });
    }),
  editItem: collectiveProcedure
    .input(
      z.object({
        shoppingListId: z.string().nonempty(),
        itemId: z.string().nonempty(),
        item: z.string().nonempty(),
      }),
    )
    .mutation(async ({ ctx, input: { shoppingListId, itemId, item } }) => {
      await ctx.db.shoppingListItem.update({
        data: {
          item: item,
        },
        where: {
          shoppingListId_item: {
            shoppingListId: shoppingListId,
            item: itemId,
          },
        },
      });
    }),
});
