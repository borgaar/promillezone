import { Card } from "../../ui/card";
import ShoppingListContent from "./content";

export default async function ShoppingTile() {
  return (
    <Card className="relative max-lg:row-start-3 lg:col-start-3 lg:row-start-1">
      <ShoppingListContent />
    </Card>
  );
}
