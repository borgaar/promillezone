import { auth, signIn } from "@/server/auth";
import { api, HydrateClient } from "@/trpc/server";
import TrashTile from "../components/bento-grid/trash/tile";
import BusTile from "../components/bento-grid/bus/tile";
import ShoppingTile from "../components/bento-grid/shopping/tile";
import CreateCollectiveForm from "./create-collective-form";
import ChoresTile from "../components/bento-grid/chores/tile";
import BookingTile from "../components/bento-grid/booking/tile";
import ErikTile from "../components/bento-grid/erik/tile";

export default async function Home() {
  const session = await auth();

  if (!session) {
    return signIn();
  }

  try {
    const _ = await api.collective.getCollective();

    return <Page />;
  } catch {
    return <NoCollective />;
  }
}

function Page() {
  return (
    <HydrateClient>
      <main>
        <div className="mx-auto flex w-full flex-col gap-4 px-2 sm:mt-4 sm:px-3 lg:grid lg:h-[calc(100svh-6rem)] lg:grid-cols-3 lg:grid-rows-2 lg:px-4">
          <TrashTile />
          {/* <MembersTile /> */}
          <BusTile />
          <ErikTile />
          <ShoppingTile />
          <ChoresTile />
          <BookingTile />
        </div>
      </main>
    </HydrateClient>
  );
}

function NoCollective() {
  return (
    <div className="flex h-[100svh] w-full items-center justify-center">
      <CreateCollectiveForm />
    </div>
  );
}
