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

const FormSchema = z.object({
  collectiveName: z
    .string()
    .min(1, "Minst 1 bokstav")
    .max(28, "For langt navn"),
  streetName: z.string().min(1, "Må fylles ut"),
  houseNumber: z
    .string()
    .min(1, "Må fylles ut")
    .refine((value) => {
      return !isNaN(Number(value));
    }, "Må være et tall"),
  postalCode: z
    .string()
    .length(4, "Må være 4 tegn")
    .refine((value) => {
      return !isNaN(Number(value));
    }, "Må være et tall"),
});

export default function CreateCollectiveForm() {
  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      collectiveName: "",
      streetName: "",
      houseNumber: "",
      postalCode: "",
    },
  });

  const { mutateAsync: createCollective } =
    api.collective.createCollective.useMutation();

  const router = useRouter();

  async function onSubmit(data: z.infer<typeof FormSchema>) {
    await createCollective(data);
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
          name="streetName"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Gatenavn</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <div className="flex w-full justify-between space-x-4">
          <FormField
            control={form.control}
            name="houseNumber"
            render={({ field }) => (
              <FormItem className="w-full">
                <FormLabel>Husnummer</FormLabel>
                <FormControl>
                  <Input {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <FormField
            control={form.control}
            name="postalCode"
            render={({ field }) => (
              <FormItem className="w-full">
                <FormLabel>Postnummer</FormLabel>
                <FormControl>
                  <Input {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
        </div>

        <Button type="submit" className="w-full">
          Opprett kollektiv
        </Button>
      </form>
    </Form>
  );
}
