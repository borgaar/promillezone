"use client";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Edit, Save } from "lucide-react";
import { useState } from "react";
import { api } from "../../../trpc/react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import type { ShoppingListItem } from "./content";
import { useToast } from "../../../hooks/use-toast";

const formSchema = z.object({
  item: z.string(),
});

export function EditItemDialog({ item }: { item: ShoppingListItem }) {
  const utils = api.useUtils();
  const { mutateAsync: editItem } = api.shoppingList.editItem.useMutation({
    onMutate: async (mutation) => {
      // Cancel any outgoing refetches
      // (so they don't overwrite our optimistic update)
      await utils.shoppingList.getShoppingList.cancel();

      const previous = utils.shoppingList.getShoppingList.getData();

      if (!previous) return;

      const updated = previous.map((item) => {
        if (item.item === mutation.oldName) {
          return {
            ...item,
            item: mutation.newName,
          };
        }

        return item;
      });

      utils.shoppingList.getShoppingList.setData(undefined, updated);

      return { previous };
    },
    onError: (_error, _newItem, context) => {
      utils.shoppingList.getShoppingList.setData(undefined, context?.previous);
    },
    onSettled: () => {
      void utils.shoppingList.getShoppingList.invalidate();
    },
  });
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      item: item.item,
    },
  });
  const [open, setOpen] = useState(false);
  const { toast } = useToast();

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    try {
      await editItem({
        oldName: item.item,
        newName: values.item,
      });
    } catch {
      // Duplicate item
      toast({
        title: "Kunne ikke oppdatere artikkelen",
        description: "Det finnes allerede en artikkel med dette navnet",
        variant: "destructive",
      });
    }

    setOpen(false);
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="icon">
          <Edit />
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)}>
            <DialogHeader>
              <DialogTitle>Legg til en artikkel</DialogTitle>
            </DialogHeader>
            <FormField
              control={form.control}
              name="item"
              render={({ field }) => (
                <FormItem className="my-4">
                  <FormControl>
                    <Input {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <DialogFooter>
              <Button type="submit">
                <Save /> Lagre
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
