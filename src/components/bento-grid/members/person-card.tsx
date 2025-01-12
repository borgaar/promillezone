"use client";

import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { MoreHorizontal } from "lucide-react";
import { type RouterOutputs } from "../../../trpc/react";

interface PersonCardProps {
  user: RouterOutputs["collective"]["getCollective"]["users"][number];
}

export default function PersonCard({ user }: PersonCardProps) {
  return (
    <div className="flex w-full items-center space-x-4 rounded-lg border bg-white p-4 shadow-sm dark:bg-neutral-900">
      {/* Profile Picture */}
      <Avatar>
        {user.image ? (
          <AvatarImage
            src={user.image}
            alt={`${user.name}'s profile picture`}
          />
        ) : (
          <AvatarFallback>{user.name?.charAt(0).toUpperCase()}</AvatarFallback>
        )}
      </Avatar>

      {/* Name and Permission */}
      <div className="flex-1">
        <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
          {user.name}
        </p>
        {/* <p className="text-xs text-gray-500 dark:text-neutral-300">
          {user.}
        </p> */}
      </div>

      {/* Menu Button */}
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon">
            <MoreHorizontal className="h-5 w-5" />
          </Button>
        </DropdownMenuTrigger>
        {/* <DropdownMenuContent align="end">
          <DropdownMenuItem onClick={() => {}}>
            Fjerne fra kollektivet
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => {}}>Gjør til admin</DropdownMenuItem>
        </DropdownMenuContent> */}
      </DropdownMenu>
    </div>
  );
}
