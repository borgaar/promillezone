import { auth, signIn } from "@/server/auth";
import { api, HydrateClient } from "@/trpc/server";
import { MembersTile } from "../components/bento-grid/members/tile";
import TrashTile from "../components/bento-grid/trash/tile";
import BusTile from "../components/bento-grid/bus/tile";
import ShoppingTile from "../components/bento-grid/shopping/tile";
import CreateCollectiveForm from "./create-collective-form";

export default async function Home() {
  const session = await auth();

  if (!session) {
    return signIn();
  }

  try {
    const collective = await api.collective.getCollective();

    return <Page />;
  } catch {
    return <NoCollective />;
  }
}

function Page() {
  return (
    <HydrateClient>
      <main>
        <div className="mx-auto grid w-full gap-4 px-2 sm:mt-4 sm:px-3 lg:grid-cols-3 lg:grid-rows-2 lg:px-4">
          <TrashTile />
          <MembersTile />
          <BusTile />
          <ShoppingTile />
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
