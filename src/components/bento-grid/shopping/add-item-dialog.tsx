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
import { Plus } from "lucide-react";
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
import { useToast } from "../../../hooks/use-toast";

const formSchema = z.object({
  item: z.string(),
});

export function AddItemDialog({ onComplete }: { onComplete: () => void }) {
  const { mutateAsync: addToList } =
    api.shoppingList.addItemToShoppingList.useMutation();
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      item: "",
    },
  });
  const [open, setOpen] = useState(false);
  const { toast } = useToast();

  const onSubmit = async (values: z.infer<typeof formSchema>) => {
    try {
      await addToList(values.item);
      onComplete();
      setOpen(false);
    } catch {
      toast({
        title: "Kunne ikke legge til artikkelen",
        description: "Det finnes allerede en artikkel med dette navnet",
        variant: "destructive",
      });
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Plus />
          Legg til
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
                {" "}
                <Plus />
                Legg til
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
