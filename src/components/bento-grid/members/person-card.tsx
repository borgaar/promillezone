"use client";

import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { MoreHorizontal } from "lucide-react";

interface PersonCardProps {
  name: string;
  permission: string;
  profilePictureUrl?: string;
  onRemove: () => void;
  onMakeAdmin: () => void;
}

export default function PersonCard({
  name,
  permission,
  profilePictureUrl,
  onRemove,
  onMakeAdmin,
}: PersonCardProps) {
  return (
    <div className="flex w-full items-center space-x-4 rounded-lg border bg-white p-4 shadow-sm">
      {/* Profile Picture */}
      <Avatar>
        {profilePictureUrl ? (
          <AvatarImage
            src={profilePictureUrl}
            alt={`${name}'s profile picture`}
          />
        ) : (
          <AvatarFallback>{name.charAt(0).toUpperCase()}</AvatarFallback>
        )}
      </Avatar>

      {/* Name and Permission */}
      <div className="flex-1">
        <p className="text-sm font-medium text-gray-900">{name}</p>
        <p className="text-xs text-gray-500">{permission}</p>
      </div>

      {/* Menu Button */}
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon">
            <MoreHorizontal className="h-5 w-5" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem onClick={onRemove}>
            Fjerne fra kollektivet
          </DropdownMenuItem>
          <DropdownMenuItem onClick={onMakeAdmin}>
            Gjør til admin
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
}
