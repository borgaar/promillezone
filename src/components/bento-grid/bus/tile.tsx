import { Bus } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";

export default function BusTile() {
  return (
    <Card className="relative lg:col-start-2 lg:col-end-3 lg:row-start-1">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Bus strokeWidth={2.5} /> Buss
          </span>
          {/* <EditBusDialog /> */}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex h-full w-full items-center justify-center">
          Bussruter kommer snart!
        </div>
        {/* <BusTimeTable /> */}
      </CardContent>
    </Card>
  );
}
