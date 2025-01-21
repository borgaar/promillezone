"use client";

import { nb } from "date-fns/locale";
import * as React from "react";
import { Calendar } from "@/components/ui/calendar";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { api } from "../../../trpc/react";
import { useState } from "react";

export default function PickDateDialog() {
  const { mutateAsync: book } = api.room.createRoomBooking.useMutation();

  const [date, setDate] = React.useState<Date | undefined>(new Date());
  const [open, setOpen] = useState(false);

  const handleSubmit = async () => {
    if (!date) return;
    await book(date);
    setOpen(false);
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">Book</Button>
      </DialogTrigger>
      <DialogContent className="w-fit">
        <DialogHeader>
          <DialogTitle>Booke fellesarealet</DialogTitle>
          <DialogDescription>
            Velg en dato for å booke fellesarealet.
          </DialogDescription>
        </DialogHeader>
        <Calendar
          locale={nb}
          mode="single"
          selected={date}
          onSelect={setDate}
          className="rounded-md border"
        />
        <DialogFooter>
          <Button onClick={handleSubmit}>Lagre</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
