import { useState } from "react";
import { Button } from "../../ui/button";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "../../ui/card";
import { Input } from "../../ui/input";

export interface Address {
  id: string;
  adresse: string;
}

export default function TrashSetup() {
  const [address, setAddress] = useState("");
  const [step, setStep] = useState(0);

  const submitAddress = async () => {
    // TODO use backend endpoint
    // const response = await fetch(
    //   `https://trv.no/wp-json/wasteplan/v2/adress/?s=${address}`,
    // );

    // if (response.status === 200) {
    //   const data = (await response.json()) as Address[];

    //   console.log(data);
    // } else {
    //   console.error("Failed to fetch address", response);
    // }

    setTimeout(() => {
      setStep((s) => s + 1);
    }, 300);
  };

  const Step = () => {
    if (step === 0) {
      return (
        <div className="flex w-full max-w-sm items-center space-x-2">
          <Input
            type="email"
            placeholder="Din addresse"
            onChange={(e) => setAddress(e.target.value)}
            value={address}
          />
          <Button onClick={submitAddress}>Søk</Button>
        </div>
      );
    }
  };

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>Kom i gang</CardTitle>
        <CardDescription>
          Skriv inn addressen til kollektivet ditt nedenfor for å hente
          tømmeplanen din. Tømmeplanen er levert av{" "}
          <a href="https://trv.no/" className="underline" target="_blank">
            Trondheim Renholdsverk
          </a>
          .
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Step />
      </CardContent>
    </Card>
  );
}
