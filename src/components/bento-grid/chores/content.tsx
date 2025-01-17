"use client";

import { api, type RouterOutputs } from "../../../trpc/react";
import { CardContent, CardFooter, CardHeader, CardTitle } from "../../ui/card";
import { BookCheck, ChevronLeft, ChevronRight } from "lucide-react";
import { AddChoreDialog } from "./add-chore-dialog";
import ChoreItem from "./item";
import { Button } from "../../ui/button";
import { addDays, endOfWeek, getWeek, startOfWeek } from "date-fns";
import { useCallback, useEffect, useMemo, useState } from "react";
import { ConfigureChoresDialog } from "./configure-chores-dialog";

export type ChoreItem = RouterOutputs["chore"]["getDueChores"][number];

export default function ChoresContent() {
  const [date, setDate] = useState(new Date());
  const from = useMemo(() => startOfWeek(date, { weekStartsOn: 1 }), [date]);
  const to = useMemo(() => endOfWeek(date, { weekStartsOn: 1 }), [date]);

  useEffect(() => {
    console.log("BRUH", from, to);
  }, [from, to]);

  const { data: chores, refetch } = api.chore.getDueChores.useQuery({
    from,
    to,
  });

  useEffect(() => {
    console.log(chores);
  }, [chores]);

  const incrementWeek = useCallback(
    () => setDate((prev) => addDays(prev, 7)),
    [],
  );

  const decrementWeek = useCallback(
    () => setDate((prev) => addDays(prev, -7)),
    [],
  );

  const week = useMemo(() => getWeek(date, { weekStartsOn: 1 }), [date]);

  return (
    <>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="mt-2 flex gap-2">
            <BookCheck strokeWidth={2.5} /> Arbeidsoppgaver
          </span>
          <div className="flex w-full items-center justify-end gap-2">
            {/* <ConfigureChoresDialog /> */}
          </div>
        </CardTitle>
      </CardHeader>
      <CardContent className="flex-grow space-y-4">
        Arbeidsoppgaver kommer snart!
        {/* {Boolean(chores) &&
          chores!.map((chore) => (
            <ChoreItem
              key={chore.description + chore.dueDate.toISOString()}
              chore={chore}
            />
          ))} */}
      </CardContent>
      {/* <CardFooter className="flex items-center justify-end gap-2">
        <Button variant={"outline"} size={"icon"} onClick={decrementWeek}>
          <ChevronLeft />
        </Button>
        <span>Uke {week}</span>
        <Button variant={"outline"} size={"icon"} onClick={incrementWeek}>
          <ChevronRight />
        </Button>
      </CardFooter> */}
    </>
  );
}
