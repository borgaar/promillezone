import { Bus, Edit } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";
import { Button } from "../../ui/button";
import BusTimeTable from "./time-table";

export default function BussTile() {
  return (
    <Card className="relative max-lg:row-start-3 lg:col-start-2 lg:row-start-2">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Bus strokeWidth={2.5} /> Buss
          </span>
          <Button variant="outline">
            <Edit />
            Endre
          </Button>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <BusTimeTable />
      </CardContent>
    </Card>
  );
}
