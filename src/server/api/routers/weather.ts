import { createTRPCRouter, collectiveProcedure } from "@/server/api/trpc";
import { type WeatherData, WeatherProvider } from "@/server/weather/yr";
import { TRPCError } from "@trpc/server";

export const weatherRouter = createTRPCRouter({
  getWeather: collectiveProcedure.query(
    async ({ ctx }): Promise<WeatherData> => {
      const data = (await ctx.db.collective.findUniqueOrThrow({
        where: {
          id: ctx.session.user.collectiveId,
        },
        select: {
          coordinates: true,
        },
      })) as { coordinates: string | null };

      const coordinates = data.coordinates;

      if (!coordinates) {
        throw new TRPCError({
          code: "PRECONDITION_FAILED",
          message: "Collective has no coordinates in database",
        });
      }

      if (!coordinates.includes(",")) {
        throw new TRPCError({
          code: "INTERNAL_SERVER_ERROR",
          message: `Collective has invalid coordinates format: ${coordinates}`,
        });
      }

      const [lat, lon] = coordinates.split(",") as [string, string];

      try {
        return await WeatherProvider.getForecast(lat, lon);
      } catch (e) {
        console.error(e);
        throw new TRPCError({
          code: "INTERNAL_SERVER_ERROR",
          message: "Failed to fetch weather data",
        });
      }
    },
  ),
});
