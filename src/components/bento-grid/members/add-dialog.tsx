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
import { Check, Copy, Plus } from "lucide-react";
import { Textarea } from "@/components/ui/textarea";
import { useEffect, useState } from "react";

export function AddMemberDialogButton() {
  const [isCopied, setIsCopied] = useState(false);

  useEffect(() => {
    if (isCopied) {
      setTimeout(() => {
        setIsCopied(false);
      }, 1000);
    }
  }, [isCopied]);
  // TODO fetch url to invite member

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Plus />
          Legg til
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Legg til et medlem</DialogTitle>
          <DialogDescription>
            Kopier lenken nedenfor og send den til personen du vil legge til.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <Textarea
            value={
              "https://promille.zone/invite?code=9fn34uq20fi423opmjvfioq34pfnjiq40å3nvfji4qpofjmvio4apwqfnuq82340åmvrufi34q2opnurv23q4årnuviopøfjmeowpufå"
            }
            className="resize-none"
          />
        </div>
        <DialogFooter>
          <Button
            onClick={() => setIsCopied(true)}
            variant="outline"
            disabled={isCopied}
          >
            {isCopied ? (
              <>
                <Check /> Kopiert!
              </>
            ) : (
              <>
                <Copy /> Kopièr lenke
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
