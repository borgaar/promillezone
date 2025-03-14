import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { z } from "zod";
import { TRPCError } from "@trpc/server";

export const busRouter = createTRPCRouter({
    getNearestBusStops: collectiveProcedure.query(async ({ ctx }) => {
        const busStops = await ctx.db.busStop.findMany({
            where: {
                collectiveId: ctx.session.user.collectiveId,
            },
        });

        return busStops;
    }),
});
