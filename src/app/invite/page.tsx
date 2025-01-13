import Link from "next/link";
import { api } from "../../trpc/server";
import JoinButton from "./join-button";

export default async function InvitePage({
  searchParams,
}: {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  searchParams?: any;
}) {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
  const inviteToken = searchParams?.code as string | undefined;

  if (!inviteToken) {
    return <NotFound />;
  }

  const collective = await api.collective.getCollectivePreview(inviteToken);

  if (!collective) {
    return <NotFound />;
  }

  return (
    <div className="bg-white">
      <div className="px-6 py-24 sm:px-6 sm:py-32 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-balance text-4xl font-semibold tracking-tight text-gray-900 sm:text-5xl">
            Du har blitt invitert til å bli med i {collective.name}
          </h2>
          <div className="mt-10 flex items-center justify-center gap-x-6">
            <JoinButton token={inviteToken} />
          </div>
        </div>
      </div>
    </div>
  );
}

function NotFound() {
  return (
    <>
      <main className="grid min-h-full place-items-center bg-white px-6 py-24 sm:py-32 lg:px-8">
        <div className="text-center">
          <p className="text-base font-semibold text-neutral-600">404</p>
          <h1 className="mt-4 text-balance text-5xl font-semibold tracking-tight text-gray-900 sm:text-7xl">
            Oj, den lenken funker ikke lenger!
          </h1>
          <p className="mt-6 text-pretty text-lg font-medium text-gray-500 sm:text-xl/8">
            Enten er kollektivet slettet, eller så har lenken gått ut på dato.
            Vi foreslår at du spør den som inviterte deg om en ny lenke.
          </p>
          <div className="mt-10 flex items-center justify-center gap-x-6">
            <Link
              href="/"
              className="rounded-md bg-neutral-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-neutral-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-600"
            >
              Gå hjem
            </Link>
            {/* <a href="#" className="text-sm font-semibold text-gray-900">
              Contact support <span aria-hidden="true">&rarr;</span>
            </a> */}
          </div>
        </div>
      </main>
    </>
  );
}
