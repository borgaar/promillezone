import * as React from "react";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import PersonCard from "./person-card";
import { AddMemberDialogButton } from "./add-dialog";
import { Users } from "lucide-react";
import { api } from "../../../trpc/server";

export async function MembersTile() {
  const collective = await api.collective.getCollective();

  return (
    <Card className="relative max-lg:row-start-1">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Users strokeWidth={2.5} /> Medlemmer
          </span>
          <AddMemberDialogButton />
        </CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col items-start justify-start gap-2">
        {collective.users.map((user) => (
          <PersonCard user={user} key={user.id} />
        ))}
      </CardContent>
    </Card>
  );
}
