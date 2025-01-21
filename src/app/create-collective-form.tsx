"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { api } from "../trpc/react";
import { useRouter } from "next/navigation";
import {
  type Address,
  AddressSearchCombobox,
} from "@/components/ui/address-search";

const AddressSchema = z.object({
  adressenavn: z.string().min(1, "Streetname is required"),
  nummer: z.string().min(1, "Number is required"),
  bokstav: z.string(),
  poststed: z.string().min(1, "City is required"),
  postnummer: z.string().length(4, "Postal code must be 4 digits"),
  representasjonspunkt: z.object({
    lat: z.number(),
    lon: z.number(),
  }),
});

const FormSchema = z.object({
  collectiveName: z
    .string()
    .min(1, "Minst 1 bokstav")
    .max(28, "For langt navn"),
  address: AddressSchema.refine((val) => val.adressenavn !== "", {
    message: "Hva er din adresse?",
  }),
});

export default function CreateCollectiveForm() {
  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      collectiveName: "",
      address: {
        adressenavn: "",
        nummer: "",
        bokstav: "",
        postnummer: "",
        poststed: "",
        representasjonspunkt: {
          lat: 0,
          lon: 0,
        },
      },
    },
  });

  const { mutateAsync: createCollective } =
    api.collective.createCollective.useMutation();

  const router = useRouter();

  async function onSubmit(data: z.infer<typeof FormSchema>) {
    await createCollective({
      collectiveName: data.collectiveName,
      address: {
        streetName: data.address.adressenavn,
        streetNumber: data.address.nummer,
        streetLetter: data.address.bokstav,
        postalCity: data.address.poststed,
        postalCode: data.address.postnummer,
        coordinates: {
          lat: data.address.representasjonspunkt.lat,
          lon: data.address.representasjonspunkt.lon,
        },
      },
    });
    router.refresh();
  }

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="w-full max-w-md space-y-6"
      >
        <div>
          <div className="text-xl font-bold">
            Opprett kollektivet ditt for å komme i gang
          </div>
          <div className="mt-1 text-lg font-normal text-neutral-600 dark:text-neutral-300">
            eller be en venn om å invitere deg
          </div>
        </div>
        <FormField
          control={form.control}
          name="collectiveName"
          render={({ field }) => (
            <FormItem className="w-full">
              <FormLabel>Navn på kollektivet</FormLabel>
              <FormControl className="w-full">
                <Input {...field} className="w-full" />
              </FormControl>
              <FormDescription>Dette velger du helt selv</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="address"
          render={() => (
            <FormItem className="flex w-full flex-col">
              <FormLabel>Kollektivets adresse</FormLabel>
              <FormControl className="w-full">
                <AddressSearchCombobox
                  onSelect={(address: Address) => {
                    form.setValue("address", address);
                  }}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit" className="w-full">
          Opprett kollektiv
        </Button>
      </form>
    </Form>
  );
}
