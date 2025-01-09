"use client";

import { Input } from "../../ui/input";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { toast } from "@/hooks/use-toast";
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
import { api } from "../../../trpc/react";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";
import { TRPCError } from "@trpc/server";
import { TRPCClientError } from "@trpc/client";

const FormSchema = z.object({
  provider: z.string(),
  address: z.string(),
});

export function TrashSetup() {
  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      address: "",
      provider: "trv",
    },
  });

  const { mutateAsync: setupProvider } = api.trash.setupProvider.useMutation();

  const router = useRouter();

  const onSubmit = async (data: z.infer<typeof FormSchema>) => {
    try {
      await setupProvider({
        address: data.address,
        providerSlug: data.provider,
      });
    } catch (error) {
      if (error instanceof TRPCClientError) {
        toast({
          title: "Oops, noe gikk galt!",
          description: error.message,
        });
      }

      return;
    }

    toast({
      title: "Søppelkalenderen din er nå satt opp!",
    });

    router.refresh();
  };

  return (
    <Card>
      <CardHeader>
        <CardHeader>
          <CardTitle>Kom i gang med tømmeplan!</CardTitle>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form
              onSubmit={form.handleSubmit(onSubmit)}
              className="w-full space-y-6"
            >
              <FormField
                control={form.control}
                name="address"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Adresse</FormLabel>
                    <FormControl>
                      <Input placeholder="Adresseveien 1" {...field} />
                    </FormControl>
                    <FormDescription>
                      Vi trenger adressen din for å kunne gi deg riktig
                      søppelkalender
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <Button type="submit">Send</Button>
            </form>
          </Form>
        </CardContent>
      </CardHeader>
    </Card>
  );
}
