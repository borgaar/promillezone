"use client";

import { Check, ChevronsUpDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { useCallback, useEffect, useState } from "react";

export interface Address {
  adressenavn: string;
  nummer: string;
  bokstav: string;
  poststed: string;
  postnummer: string;
  representasjonspunkt: {
    lat: number;
    lon: number;
  };
}

const stripAddress = (address: Address) => {
  return {
    adressenavn: address.adressenavn,
    postnummer: address.postnummer,
    poststed: address.poststed,
    bokstav: address.bokstav,
    nummer: address.nummer.toString(),
    representasjonspunkt: {
      lat: address.representasjonspunkt.lat,
      lon: address.representasjonspunkt.lon,
    },
  } as Address;
};

export function AddressSearchCombobox({
  onSelect,
}: {
  onSelect: (address: Address) => void;
}) {
  const [open, setOpen] = useState(false);
  const [value, setValue] = useState<Address | null>(null);
  const [addresses, setAddresses] = useState<Address[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");

  const searchAddresses = useCallback(async (search: string) => {
    if (search.trim().length < 3) {
      setAddresses([]);
      return;
    }

    setLoading(true);

    try {
      const response = await fetch(
        "https://ws.geonorge.no/adresser/v1/sok?" +
          new URLSearchParams({ fuzzy: "true", sok: search.trim() }).toString(),
      );
      const data = (await response.json()) as { adresser: Address[] };
      const strippedAddresses = data.adresser.map(stripAddress);
      setAddresses(strippedAddresses);
    } catch (error) {
      console.error("Error fetching addresses:", error);
      setAddresses([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const delayDebounceFn = setTimeout(() => {
      void searchAddresses(searchTerm);
    }, 300);

    return () => clearTimeout(delayDebounceFn);
  }, [searchTerm, searchAddresses]);

  const getMessage = () => {
    if (searchTerm.trim() === "") return "Søk etter en adresse";
    if (loading) return "Søker etter adresser...";
    if (addresses.length === 0) return "Vi fant ingen adresser";
    return null;
  };

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className="justify-between"
        >
          {value
            ? `${value.adressenavn} ${value.nummer}${value.bokstav}, ${value.postnummer} ${value.poststed}`
            : "Search for an address..."}
          <ChevronsUpDown className="ml-2 h-4 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-96 p-0 shadow-lg">
        <Command>
          <CommandInput
            placeholder="Søk etter en adresse"
            value={searchTerm}
            onValueChange={(term) => {
              setSearchTerm(term);
            }}
          />
          <CommandList>
            {getMessage() && <CommandEmpty>{getMessage()}</CommandEmpty>}
            <CommandGroup>
              {addresses.map((address) => (
                <CommandItem
                  key={JSON.stringify(address)}
                  value={JSON.stringify(address)}
                  onSelect={() => {
                    setValue(address);
                    onSelect(address);
                    setOpen(false);
                  }}
                >
                  <Check
                    className={cn(
                      "mr-2 h-4 w-4",
                      JSON.stringify(value) === JSON.stringify(address)
                        ? "opacity-100"
                        : "opacity-0",
                    )}
                  />
                  {address.adressenavn} {address.nummer}
                  {address.bokstav}, {address.postnummer} {address.poststed}
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}
