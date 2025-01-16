import { BookCheck, Bus } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";

export default function BookingTile() {
  return (
    <Card className="relative max-lg:row-start-2 lg:col-start-3 lg:row-start-2">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <BookCheck strokeWidth={2.5} /> Rombooking
          </span>
          {/* <EditBusDialog /> */}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex h-full w-full items-center justify-center">
          Rombooking kommer snart!
        </div>
        {/* <BusTimeTable /> */}
      </CardContent>
    </Card>
  );
}
