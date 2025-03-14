import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { z } from "zod";
import { TRPCError } from "@trpc/server";
import { gql, request } from "graphql-request";

interface Departure {
  code: string;
  name: string;
  realtime: boolean;
  aimedArrivalTime: Date;
  expectedArrivalTime: Date;
}

interface BusStop {
  name: string;
  id: string;
  latitude: number;
  longitude: number;
}

export interface BusDeparture extends BusStop {
  departures: Departure[];
}

export const busRouter = createTRPCRouter({
  // Get three closest bus stops
  getDepartures: collectiveProcedure.query(async ({ ctx }) => {
    const busStops = await getBusStops(ctx);
    const busStopIds = busStops.map((busStop) => busStop.id);

    return queryBusDepartures(busStopIds);
  }),
});

async function getBusStops(ctx: any): Promise<BusStop[]> {
  const dbBusStops = await ctx.db.busStop.findMany({
    where: {
      CollectiveBusStop: {
        some: {
          collectiveId: ctx.session.user.collectiveId,
        },
      },
    },
    include: {
      CollectiveBusStop: true,
    },
  });

  let busStops: BusStop[] = dbBusStops.map((dbBusStop: any) => ({
    name: dbBusStop.name,
    id: dbBusStop.id,
    latitude: dbBusStop.latitude,
    longitude: dbBusStop.longitude,
  }));

  if (busStops.length == 0) {
    const coordinates_str = await ctx.db.collective.findUnique({
      where: {
        id: ctx.session.user.collectiveId,
      },
      select: {
        coordinates: true,
      },
    });

    if (!coordinates_str) {
      throw new TRPCError({
        code: "INTERNAL_SERVER_ERROR",
        message: "No coordinates found for collective",
      });
    }

    const coordinates = coordinates_str.coordinates.split(",").map(Number);
    busStops = await queryClosestBusStops(coordinates[0]!, coordinates[1]!);
  }

  return busStops;
}

async function queryClosestBusStops(
  latitude: number,
  longitude: number,
): Promise<BusStop[]> {
  const document = gql`
  {
    nearest(
      latitude: ${latitude}
      longitude: ${longitude}
      maximumDistance: 2000
      maximumResults: 3
      filterByInUse: true
      multiModalMode: parent
      filterByPlaceTypes: [stopPlace]
  ) {
      edges {
        node {
          distance
          place {
            ... on StopPlace {
              name
            }
            id
            latitude
            longitude
          }
        }
      }
    }
  }`;

  interface Data {
    nearest: Nearest;
  }

  interface Nearest {
    edges: Edge[];
  }

  interface Edge {
    node: Node;
  }

  interface Node {
    distance: number;
    place: Place;
  }

  interface Place {
    name: string;
    id: string;
    latitude: number;
    longitude: number;
  }

  const url = "https://api.entur.io/journey-planner/v3/graphql";
  const data: Data = await request(url, document);
  return data.nearest.edges.map((edge) => ({
    name: edge.node.place.name,
    id: edge.node.place.id,
    latitude: edge.node.place.latitude,
    longitude: edge.node.place.longitude,
  }));
}

async function queryBusDepartures(ids: string[]): Promise<BusDeparture[]> {
  const document = gql`
  {
    stopPlaces(ids: [${ids.map((id) => `"${id}"`).join(",")}]) {
      id
      name
      latitude
      longitude
      estimatedCalls(timeRange: 7200, numberOfDepartures: 5) {
        realtime
        aimedArrivalTime
        expectedArrivalTime
        destinationDisplay {
          frontText
        }
        serviceJourney {
          line {
            publicCode
          }
        }
      }
    }
  }`;
  interface Data {
    stopPlaces: StopPlace[];
  }

  interface StopPlace {
    id: string;
    name: string;
    latitude: number;
    longitude: number;
    estimatedCalls: EstimatedCall[];
  }

  interface EstimatedCall {
    realtime: boolean;
    aimedArrivalTime: Date;
    expectedArrivalTime: Date;
    destinationDisplay: DestinationDisplay;
    serviceJourney: ServiceJourney;
  }

  interface DestinationDisplay {
    frontText: string;
  }

  interface ServiceJourney {
    line: Line;
  }

  interface Line {
    publicCode: string;
  }

  const url = "https://api.entur.io/journey-planner/v3/graphql";
  const data: Data = await request(url, document);

  return data.stopPlaces.map((stopPlace) => ({
    name: stopPlace.name,
    id: stopPlace.id,
    latitude: stopPlace.latitude,
    longitude: stopPlace.longitude,
    departures: stopPlace.estimatedCalls.map((call) => ({
      code: call.serviceJourney.line.publicCode,
      name: call.destinationDisplay.frontText,
      realtime: call.realtime,
      aimedArrivalTime: call.aimedArrivalTime,
      expectedArrivalTime: call.expectedArrivalTime,
    })),
  }));
}
