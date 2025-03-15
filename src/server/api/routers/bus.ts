import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { getBusStops, queryBusDepartures } from "@/server/bus/departures";

export const busRouter = createTRPCRouter({
  // Get three closest bus stops
  getDepartures: collectiveProcedure.query(async ({ ctx }) => {
    const busStops = await getBusStops(ctx);
    const busStopIds = busStops.map((busStop) => busStop.id);

    return queryBusDepartures(busStopIds);
  }),
});
