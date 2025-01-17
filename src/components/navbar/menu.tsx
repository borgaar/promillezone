"use client";

import { Menu, MenuButton, MenuItem, MenuItems } from "@headlessui/react";
import { signIn, signOut } from "next-auth/react";
import type { auth } from "../../server/auth";

export default function NavbarMenu({
  session,
}: {
  session: ReturnType<typeof auth>;
}) {
  return (
    <Menu as="div" className="relative ml-3">
      <div>
        <MenuButton className="relative flex rounded-full bg-white text-sm focus:outline-none focus:ring-2 focus:ring-neutral-500 focus:ring-offset-2">
          <span className="absolute -inset-1.5" />
          <span className="sr-only">Open user menu</span>
          <img
            alt=""
            src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
            className="size-8 rounded-full"
          />
        </MenuButton>
      </div>
      <MenuItems
        transition
        className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black/5 transition focus:outline-none data-[closed]:scale-95 data-[closed]:transform data-[closed]:opacity-0 data-[enter]:duration-200 data-[leave]:duration-75 data-[enter]:ease-out data-[leave]:ease-in"
      >
        {Boolean(session) ? (
          <>
            {/* <MenuItem>
              <a
                href="#"
                className="block px-4 py-2 text-sm text-gray-700 data-[focus]:bg-gray-100 data-[focus]:outline-none"
              >
                Instillinger
              </a>
            </MenuItem> */}
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
