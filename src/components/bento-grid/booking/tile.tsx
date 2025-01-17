import { BookCheck, Bus } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "../../ui/card";
import BookingContent from "./bookings";
import PickDateDialog from "./pick-date-dialog";
import Bookings from "./bookings";

export default function BookingTile() {
  return (
    <Card className="relative max-lg:row-start-2 lg:col-start-3 lg:row-start-2">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <BookCheck strokeWidth={2.5} /> Vorsbooking
          </span>
          <PickDateDialog />
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-2">
        <Bookings />
      </CardContent>
    </Card>
  );
}
