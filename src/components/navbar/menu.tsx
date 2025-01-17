"use client";

import { Menu, MenuButton, MenuItem, MenuItems } from "@headlessui/react";
import { signIn, signOut } from "next-auth/react";
import { MenuIcon } from "lucide-react";
import type { Session } from "next-auth";

export default function NavbarMenu({ session }: { session: Session | null }) {
  return (
    <Menu as="div" className="relative">
      <div>
        <MenuButton className="relative flex rounded-md bg-white text-sm focus:outline-none focus:ring-2 focus:ring-neutral-500 focus:ring-offset-2">
          <span className="absolute -inset-1.5" />
          <span className="sr-only">Open user menu</span>
          {Boolean(session?.user.image) ? (
            <img
              alt=""
              src={session!.user.image!}
              className="size-8 rounded-md"
            />
          ) : (
            <MenuIcon />
          )}
        </MenuButton>
      </div>
      <MenuItems
        transition
        className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black/5 transition focus:outline-none data-[closed]:scale-95 data-[closed]:transform data-[closed]:opacity-0 data-[enter]:duration-200 data-[leave]:duration-75 data-[enter]:ease-out data-[leave]:ease-in"
      >
        {Boolean(session) ? (
          <>
            <MenuItem>
              <a
                href="#"
                className="block px-4 py-2 text-sm text-gray-700 data-[focus]:bg-gray-100 data-[focus]:outline-none"
                onClick={() => signOut()}
              >
                Logg ut
              </a>
            </MenuItem>
          </>
        ) : (
          <MenuItem>
            <a
              href="#"
              className="block px-4 py-2 text-sm text-gray-700 data-[focus]:bg-gray-100 data-[focus]:outline-none"
              onClick={() => signIn("google")}
            >
              Logg inn
            </a>
          </MenuItem>
        )}
      </MenuItems>
    </Menu>
  );
}
