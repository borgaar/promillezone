import { Bus } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";
import BusTimeTable from "./time-table";
import { EditBusDialog } from "./edit-dialog";

export default function BusTile() {
  return (
    <Card className="relative max-lg:row-start-3 lg:col-start-2 lg:row-start-2">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Bus strokeWidth={2.5} /> Buss
          </span>
          <EditBusDialog />
        </CardTitle>
      </CardHeader>
      <CardContent>
        <BusTimeTable />
      </CardContent>
    </Card>
  );
}
