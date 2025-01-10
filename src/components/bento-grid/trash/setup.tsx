"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import Image from "next/image";

import { toast } from "@/hooks/use-toast";
import { Button } from "@/components/ui/button";
import { Form, FormControl, FormField, FormItem } from "@/components/ui/form";
import { api } from "../../../trpc/react";
import { useRouter } from "next/navigation";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "../../ui/card";
import { TRPCClientError } from "@trpc/client";
import { Radio, RadioGroup } from "@headlessui/react";
import { CheckCircleIcon } from "lucide-react";

const FormSchema = z.object({
  providerSlug: z.string(),
});

export function TrashSetup() {
  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
  });

  const { mutateAsync: setupProvider } = api.trash.setupProvider.useMutation();

  const { data: providers } = api.trash.getProviders.useQuery();

  const router = useRouter();

  console.log(JSON.stringify(providers, null, 2));

  const onSubmit = async (data: z.infer<typeof FormSchema>) => {
    try {
      await setupProvider({
        providerSlug: data.providerSlug,
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
          <CardDescription>Velg tømmeleverandøren din</CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form
              onSubmit={form.handleSubmit(onSubmit)}
              className="w-full space-y-6"
            >
              <FormField
                control={form.control}
                name="providerSlug"
                render={({ field }) => (
                  <FormItem>
                    <FormControl>
                      <RadioGroup
                        className="mt-6 flex gap-y-6 sm:gap-x-4"
                        onChange={field.onChange}
                        defaultValue={field.value}
                      >
                        {providers?.map((provider) => (
                          <Radio
                            key={provider.slug}
                            value={provider.slug}
                            aria-label={provider.name}
                            className="group relative flex cursor-pointer rounded-lg border border-gray-300 bg-white p-4 shadow-sm focus:outline-none data-[focus]:border-neutral-600 data-[focus]:ring-2 data-[focus]:ring-neutral-600"
                          >
                            <span className="flex flex-1 items-center gap-2">
                              {provider.logoUrl && (
                                <Image
                                  src={provider.logoUrl}
                                  alt="logo"
                                  width={30}
                                  height={30}
                                />
                              )}
                              <span className="block text-sm font-medium text-gray-900">
                                {provider.name}
                              </span>
                            </span>
                            <CheckCircleIcon
                              aria-hidden="true"
                              className="size-5 text-neutral-600 group-[&:not([data-checked])]:invisible"
                            />
                            <span
                              aria-hidden="true"
                              className="pointer-events-none absolute -inset-px rounded-lg border-2 border-transparent group-data-[focus]:border group-data-[checked]:border-neutral-600"
                            />
                          </Radio>
                        ))}
                      </RadioGroup>
                    </FormControl>
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
