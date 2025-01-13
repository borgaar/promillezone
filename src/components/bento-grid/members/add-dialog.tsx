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
import { api, type RouterOutputs } from "../../../trpc/react";

export function AddMemberDialogButton() {
  const { mutateAsync: createJoinToken } =
    api.collective.createJoinToken.useMutation();

  const [isCopied, setIsCopied] = useState(false);
  const [response, setResponse] = useState<
    RouterOutputs["collective"]["createJoinToken"] | null
  >(null);

  useEffect(() => {
    void createJoinToken().then(setResponse);
  }, [createJoinToken]);

  const copyUrl = async () => {
    if (!response) return;
    setIsCopied(true);

    void navigator.clipboard.writeText(response.url);
    setTimeout(() => {
      setIsCopied(false);
    }, 1000);
  };

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
            Send lenken nedenfor til den du ønsker å legge til. Lenken går ut på
            dato om 24 timer.
          </DialogDescription>
        </DialogHeader>
        {Boolean(response) && (
          <div className="grid gap-4 py-4">
            <Textarea value={response!.url} className="resize-none" readOnly />
          </div>
        )}
        <DialogFooter>
          <Button onClick={copyUrl} disabled={isCopied}>
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
