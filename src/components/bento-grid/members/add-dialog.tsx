"use client";

import ConfettiExplosion from "react-confetti-explosion";
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
import { useState } from "react";

export function AddMemberDialogButton() {
  const [isCopied, setIsCopied] = useState(false);

  const copyUrl = async () => {
    setIsCopied(true);

    void navigator.clipboard.writeText("brotherman testern");
    setTimeout(() => {
      setIsCopied(false);
    }, 1000);
  };

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
            Send lenken nedenfor til den du ønsker å legge til. Lenken kan kun
            brukes én gang.
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <Textarea
            value={
              "https://promille.zone/invite?code=9fn34uq20fi423opmjvfioq34pfnjiq40å3nvfji4qpofjmvio4apwqfnuq82340åmvrufi34q2opnurv23q4årnuviopøfjmeowpufå"
            }
            className="resize-none"
            readOnly
          />
        </div>
        <DialogFooter>
          <Button onClick={copyUrl} variant="outline" disabled={isCopied}>
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
