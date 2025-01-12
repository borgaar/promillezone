import { createCallerFactory, createTRPCRouter } from "@/server/api/trpc";
import { trashRouter } from "./routers/trash";
import { collectiveRouter } from "./routers/collective";
import { choreRouter } from "./routers/chore";
import { shoppingListRouter } from "./routers/shoppinglist";

/**
 * This is the primary router for your server.
 *
 * All routers added in /api/routers should be manually added here.
 */
export const appRouter = createTRPCRouter({
  trash: trashRouter,
  collective: collectiveRouter,
  chore: choreRouter,
  shoppingList: shoppingListRouter,
});

// export type definition of API
export type AppRouter = typeof appRouter;

/**
 * Create a server-side caller for the tRPC API.
 * @example
 * const trpc = createCaller(createContext);
 * const res = await trpc.post.all();
 *       ^? Post[]
 */
export const createCaller = createCallerFactory(appRouter);
