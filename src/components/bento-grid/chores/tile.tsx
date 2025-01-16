import { Suspense } from "react";
import { Card } from "../../ui/card";
import ChoresContent from "./content";

export default async function ChoresTile() {
  return (
    <Card className="relative max-lg:row-start-3 lg:col-start-1 lg:row-start-2">
      <Suspense>
        <ChoresContent />
      </Suspense>
    </Card>
  );
}
