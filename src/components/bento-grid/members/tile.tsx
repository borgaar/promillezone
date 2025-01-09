"use client";

import * as React from "react";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import PersonCard from "./person-card";
import { AddMemberDialogButton } from "./add-dialog";

export function MembersTile() {
  return (
    <Card className="relative max-lg:row-start-1">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span>Medlemmer</span>
          <AddMemberDialogButton />
        </CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col items-start justify-start gap-2">
        <PersonCard
          name={"Brotherman Testern"}
          permission={"Admin"}
          onRemove={() => ({})}
          onMakeAdmin={() => ({})}
        />
        <PersonCard
          name={"Borgar barland"}
          permission={"Medlem"}
          onRemove={() => ({})}
          onMakeAdmin={() => ({})}
        />
        <PersonCard
          name={"Anders Morille"}
          permission={"Medlem"}
          onRemove={() => ({})}
          onMakeAdmin={() => ({})}
        />
      </CardContent>
    </Card>
  );
}
