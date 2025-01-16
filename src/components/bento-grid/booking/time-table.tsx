import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

const BusTimeTable = () => {
  const timetable = [
    { line: "14", destination: "Tempe", departure: "1 min", platform: "1" },
    {
      line: "FB73",
      destination: "Flybuss Værnes",
      departure: "13:21",
      platform: "1",
    },
    {
      line: "3",
      destination: "Hallset via sentrum",
      departure: "4 min",
      platform: "1",
    },
    {
      line: "13",
      destination: "Sverresborg via Lerkendal",
      departure: "4 min",
      platform: "1",
    },
    { line: "14", destination: "Tempe", departure: "13:25", platform: "1" },
    { line: "3", destination: "Lohove", departure: "6 min", platform: "2" },
    { line: "3", destination: "Lohove", departure: "8 min", platform: "2" },
    {
      line: "14",
      destination: "A Strindheim via Charlottenlund",
      departure: "13:29",
      platform: "2",
    },
  ];

  return (
    <div className="mx-auto max-w-lg rounded-lg p-4 shadow">
      <h1 className="mb-4 text-2xl font-bold">Østre Berg</h1>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-16">Nr.</TableHead>
            <TableHead>Destinasjon</TableHead>
            <TableHead>Avganger</TableHead>
            <TableHead>Plf.</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {timetable.map((entry, index) => (
            <TableRow key={index}>
              <TableCell className="rounded bg-red-400 text-center font-bold text-white">
                {entry.line}
              </TableCell>
              <TableCell>{entry.destination}</TableCell>
              <TableCell>{entry.departure}</TableCell>
              <TableCell className="text-center">{entry.platform}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
};

export default BusTimeTable;
