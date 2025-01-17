import { Bus } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";
import { differenceInDays, formatDate } from "date-fns";
import { nb } from "date-fns/locale";

export default function ErikTile() {
  const date = new Date(2025, 0, 23);

  return (
    <Card className="relative lg:col-start-3 lg:col-end-4 lg:row-start-1">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Bus strokeWidth={2.5} /> Når kummer Erik?
          </span>
          {/* <EditBusDialog /> */}
        </CardTitle>
      </CardHeader>
      <CardContent className="flex h-[60%] w-full flex-col items-center justify-center">
        <div className="text-5xl font-bold">
          <span>Om</span>
          <span className="text-7xl font-black">
            {" "}
            {differenceInDays(date, new Date()) + 1}{" "}
          </span>
          <span>dager</span>
        </div>
        <div>{formatDate(date, "EEEE dd.MM.yyyy", { locale: nb })}</div>
      </CardContent>
    </Card>
  );
}
