"use client";

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
import { Edit, Save } from "lucide-react";

export function EditBusDialog() {
  const save = () => {};

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Edit />
          Endre
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Endre busstopp</DialogTitle>
          <DialogDescription>
            Velg hvilke(t) busstopp du ønsker å se avgangene til
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button onClick={save} variant="default">
            <Save />
            Lagre
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
