import type {
  Address,
  TrashCategory,
  TrashProvider,
  TrashScheduleEntry,
} from "../provider";

interface TRVAddress {
  id: string;
  adresse: string;
}

export interface Schedule {
  name: string;
  type: null;
  plan: null;
  calendar: Calendar[];
  deviations: null;
  plans_by_year: null;
  id: string;
  name_short: string;
}

export interface Calendar {
  dato: Date;
  frekvensType: number;
  frekvensIntervall: number;
  fraksjon: Fraksjon;
  fraksjonId: string;
  symbolId: number;
}

export enum Fraksjon {
  GlassOgMetallemballasje = "Glass- og metallemballasje",
  Matavfall = "Matavfall",
  PappOgPapir = "Papp og papir",
  Plastemballasje = "Plastemballasje",
  Restavfall = "Restavfall",
}

const fraksjonMap: Record<string, TrashCategory> = {
  [Fraksjon.GlassOgMetallemballasje]: "glass-metal",
  [Fraksjon.Matavfall]: "food",
  [Fraksjon.PappOgPapir]: "paper",
  [Fraksjon.Plastemballasje]: "plastic",
  [Fraksjon.Restavfall]: "rest",
};

export default class TRV implements TrashProvider {
  slug = "trv";
  name = "Trondheim Renholdsverk";
  logoUrl = "/trash-provider/trv.png";

  async getAddressId(address: Address): Promise<string> {
    const interpolated = `${address.streetName} ${address.houseNumber}`;

    const response = await fetch(
      `https://trv.no/wp-json/wasteplan/v2/adress/?s=${interpolated}`,
    );

    if (response.status !== 200) {
      throw new Error("Failed to fetch address");
    }

    const data = (await response.json()) as TRVAddress[];

    if (data.length === 0) {
      throw new Error("Address not found");
    }

    return data[0]!.id;
  }

  async getTrashSchedule(
    addressId: string,
    address: Address,
  ): Promise<TrashScheduleEntry[]> {
    const response = await fetch(
      `https://trv.no/wp-json/wasteplan/v2/calendar/${addressId}`,
    );

    if (!response.ok) {
      throw new Error("Failed to fetch trash schedule");
    }

    const data = (await response.json()) as Schedule;

    return data.calendar.map((entry) => ({
      date: entry.dato,
      type: fraksjonMap[entry.fraksjon]!,
    }));
  }
}
