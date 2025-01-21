import {
  type Address,
  type TrashCategory,
  type TrashProvider,
  type TrashScheduleEntry,
} from "../provider";

const renovationAppKey = "AE13DEEC-804F-4615-A74E-B4FAC11F0A30";

export interface Schedule {
  FraksjonId: number;
  Tommedatoer: Date[];
}

export interface ROAFAddress {
  AddressSearchResult: AddressSearchResult;
}

export interface AddressSearchResult {
  Roads: Road[];
}

export interface Road {
  Id: string;
}

const fractionIdToCategory: Record<number, TrashCategory> = {
  1: "rest",
  2: "paper",
  4: "glass-metal",
  7: "plastic",
  17: "food",
};

const roafScheduleToTrashSchedule = (
  schedule: Schedule[],
): TrashScheduleEntry[] => {
  const mapped = schedule.flatMap((schedule) =>
    schedule.Tommedatoer.map((date) => ({
      type: fractionIdToCategory[schedule.FraksjonId]!,
      date: new Date(date),
    })),
  ) satisfies TrashScheduleEntry[];

  mapped.sort((a, b) => a.date.getTime() - b.date.getTime());

  return mapped;
};

export default class Roaf implements TrashProvider {
  slug = "roaf";
  name = "ROAF";
  logoUrl = undefined;

  async getAddressId(address: Address): Promise<string> {
    const interpolated = `${address.streetName} ${address.streetNumber}`;
    const response = await fetch(
      `https://services.webatlas.no/GISLINE.Web.Services.Search.SOLR3.0/Service.svc/json/addressWeighted?searchString=${interpolated}&municipality=${address.postalCode}&weightedMunicipality=${address.postalCode}&firstIndex=0&maxNoOfResults=20`,
    );

    if (!response.ok) {
      throw new Error("Failed to fetch address");
    }

    const data = (await response.json()) as ROAFAddress;

    const addressId = data.AddressSearchResult.Roads[0]?.Id;

    if (!addressId) {
      throw new Error("Address not found");
    }

    return addressId;
  }

  async getTrashSchedule(
    addressId: string,
    address: Address,
  ): Promise<TrashScheduleEntry[]> {
    const response = await fetch(
      `https://norkartrenovasjon.azurewebsites.net/proxyserver.ashx?server=https://komteksky.norkart.no/MinRenovasjon.Api/api/tommekalender/?kommunenr=${address.postalCode}&gatenavn=${address.streetName}&gatekode=${addressId}&husnr=${address.streetNumber}`,
      {
        headers: {
          renovasjonappkey: renovationAppKey,
          kommunenr: address.postalCode,
        },
      },
    );

    if (!response.ok) {
      throw new Error("Failed to fetch trash schedule");
    }

    const data = (await response.json()) as Schedule[];

    return roafScheduleToTrashSchedule(data);
  }
}
