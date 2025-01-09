import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "../../ui/card";
import { Trash } from "lucide-react";
import { TrashSetup } from "./setup";

export default function TrashTile() {
  return (
    <Card className="relative lg:row-span-2">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex gap-2">
            <Trash strokeWidth={2.5} /> Tømmeplan
          </span>
        </CardTitle>
        <CardDescription>Se når søppelet blir tømt</CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col items-start justify-start gap-2">
        <TrashSetup />
      </CardContent>
    </Card>
  );
}
