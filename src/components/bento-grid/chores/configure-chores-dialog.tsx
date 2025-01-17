"use client";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Edit } from "lucide-react";
import { useState } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { useToast } from "../../../hooks/use-toast";
import { api, type RouterOutputs } from "../../../trpc/react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../../ui/table";
import { nb } from "date-fns/locale";
import { format } from "date-fns";

const formSchema = z.object({
  item: z.string(),
});

type Chore = RouterOutputs["chore"]["getChores"][number];

export function ConfigureChoresDialog() {
  const { data: chores } = api.chore.getChores.useQuery();

  const [selected, setSelected] = useState<Chore | null>(null);
  const [isCreating, setIsCreating] = useState(false);

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
      // await editItem({
      //   oldName: item.item,
      //   newName: values.item,
      // });
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
        <Button variant="outline">
          <Edit />
          Oppsett
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Oppsett av arbeidsoppgaver</DialogTitle>
        </DialogHeader>
        <div className="flex flex-row items-start justify-center gap-2">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Beskrivelse</TableHead>
                <TableHead>Startdato</TableHead>
                <TableHead>Frekvens (dager)</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {Boolean(chores) &&
                chores!.map((chore) => (
                  <TableRow
                    key={chore.id}
                    className="cursor-pointer"
                    onClick={() => setSelected(chore)}
                  >
                    {chore === selected ? (
                      <>
                        <TableCell className="font-medium">
                          {chore.description}
                        </TableCell>
                        <TableCell>
                          {format(chore.startingDate, "dd.MM.yyyy", {
                            locale: nb,
                          })}
                        </TableCell>
                        <TableCell>{chore.frequency}</TableCell>
                      </>
                    ) : (
                      <>
                        <TableCell className="font-medium">
                          {chore.description}
                        </TableCell>
                        <TableCell>
                          {format(chore.startingDate, "dd.MM.yyyy", {
                            locale: nb,
                          })}
                        </TableCell>
                        <TableCell>{chore.frequency}</TableCell>
                      </>
                    )}
                  </TableRow>
                ))}
            </TableBody>
          </Table>
          {Boolean(selected) && <div>Details</div>}
        </div>
      </DialogContent>
    </Dialog>
  );
}
