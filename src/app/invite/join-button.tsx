"use client";

import { useRouter } from "next/navigation";
import { Button } from "../../components/ui/button";
import { api } from "../../trpc/react";

export default function JoinButton({ token }: { token: string }) {
  const { mutateAsync: join } = api.collective.joinCollective.useMutation();
  const router = useRouter();

  return (
    <Button
      size={"lg"}
      variant={"default"}
      onClick={() => join(token).then(() => router.replace("/"))}
    >
      Bli med!
    </Button>
  );
}
