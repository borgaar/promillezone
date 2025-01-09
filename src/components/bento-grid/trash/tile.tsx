"use client";

import { useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "../../ui/card";
import PersonCard from "../members/person-card";
import { Input } from "../../ui/input";
import { Button } from "../../ui/button";
import TrashSetup from "./setup";
import { Trash } from "lucide-react";

export default function TrashTile() {
  const [addressId, setAddressId] = useState<string | null>(null);

  return (
    <Card className="relative lg:row-span-2">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Trash strokeWidth={2.5} /> Tømmeplan
          </span>
        </CardTitle>
        <CardDescription>Se når søppelet blir tømt</CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col items-start justify-start gap-2">
        <TrashSetup />
      </CardContent>
    </Card>
  );
}
