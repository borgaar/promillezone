/**
 * A single household address
 */
export interface Address {
  streetName: string;
  houseNumber: number;
  postalCode: string;
}

/**
 * Represents a provider of trash schedule information
 */
export interface TrashProvider {
  /**
   * Unique slug for this trash provider
   */
  slug: string;

  /**
   * UI-friendly name of the provider
   */
  name: string;

  /**
   * Optional URL pointing to the provider's logo
   */
  logoUrl?: string;

  /**
   * Get the provider's internal ID for a specific address
   
   */
  getAddressId(address: Address): Promise<string>;

  /**
   * Get the upcoming trash schedule for a specific address
   * @param addressId The internal ID of the address to search for
   * @param address The address to search for
   */
  getTrashSchedule(
    addressId: string,
    address: Address,
  ): Promise<TrashScheduleEntry[]>;
}

/**
 * Represents a point in time where a provider will pick up a specific type of trash
 */
export interface TrashScheduleEntry {
  date: Date;
  type: TrashCategory;
}

export type TrashCategory =
  | "plastic"
  | "paper"
  | "food"
  | "rest"
  | "glass-metal";
