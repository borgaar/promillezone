"use server";

import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";
import { Banana, Milk, Newspaper, Trash, Trash2, Wine } from "lucide-react";
import { TrashSetup } from "./setup";
import { api } from "../../../trpc/server";
import type {
  TrashCategory,
  TrashScheduleEntry,
} from "../../../server/trash/provider";
import { Avatar } from "@radix-ui/react-avatar";
import {
  addDays,
  formatDistanceToNow,
  format,
  isToday,
  isWithinInterval,
} from "date-fns";
import { nb } from "date-fns/locale";
import { useMemo } from "react";

export default async function TrashTile() {
  return (
    <Card className="relative lg:row-span-2">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Trash strokeWidth={2.5} /> Tømmeplan
          </span>
        </CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col items-start justify-start gap-2">
        <TrashTileContent />
      </CardContent>
    </Card>
  );
}

async function TrashTileContent() {
  try {
    const schedule = await api.trash.getSchedule();

    return <TrashSchedule schedule={schedule} />;
  } catch (error) {
    if (error?.code === "PRECONDITION_FAILED") {
      return <TrashSetup />;
    }

    return <div>Noe gikk galt under innlastingen</div>;
  }
}

const isWithin30DaysInFuture = (date: Date) => {
  const now = addDays(new Date(), -1);
  const futureLimit = addDays(now, 30); // 30 days from today
  return isWithinInterval(new Date(date), { start: now, end: futureLimit });
};

function TrashSchedule({ schedule }: { schedule: TrashScheduleEntry[] }) {
  const entries = useMemo(
    () => schedule.filter((e, i) => i <= 9 && isWithin30DaysInFuture(e.date)),
    [schedule],
  );

  return (
    <div className="flex w-full flex-col gap-2">
      {entries.map((entry) => (
        <TrashScheduleEntryTile
          key={new Date(entry.date).toISOString() + entry.type}
          entry={entry}
        />
      ))}
    </div>
  );
}

const trashCategoryToIcon: Record<TrashCategory, React.ReactNode> = {
  food: <Banana />,
  "glass-metal": <Wine />,
  paper: <Newspaper />,
  rest: <Trash2 />,
  plastic: <Milk />,
};

const TrashCategoryToLabel: Record<TrashCategory, string> = {
  food: "Matavfall",
  "glass-metal": "Glass- og metallemballasje",
  paper: "Papir og papp",
  rest: "Restavfall",
  plastic: "Plastemballasje",
};

const formatRelativeDate = (date: Date) => {
  if (isToday(date)) {
    return "i dag";
  }

  return formatDistanceToNow(new Date(date), {
    addSuffix: true,
    locale: nb, // Norwegian locale
  });
};

const formatDate = (date: Date) => {
  return format(date, "dd.MM");
};

function TrashScheduleEntryTile({ entry }: { entry: TrashScheduleEntry }) {
  return (
    <div className="flex w-full items-center justify-between space-x-4 rounded-lg border bg-white p-4 shadow-sm">
      <div className="flex items-center gap-2">
        <Avatar>{trashCategoryToIcon[entry.type]}</Avatar>
        <p className="text-sm font-medium text-gray-900">
          {TrashCategoryToLabel[entry.type]}
        </p>
      </div>
      <p className="">
        {formatRelativeDate(entry.date)}
        <span className="text-gray-500"> ⋅ {formatDate(entry.date)}</span>
      </p>
    </div>
  );
}
