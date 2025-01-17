"use server";

import {
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
} from "@headlessui/react";
import { Bars3Icon, XMarkIcon } from "@heroicons/react/24/outline";
import { auth } from "../../server/auth";
import NavbarMenu from "./menu";
import { ModeToggle } from "../theme/mode-toggle";
import Logo from "../logo";
import SignOutButton from "./sign-out-button";

export default async function Navbar() {
  const session = await auth();

  return (
    <Disclosure as="nav" className="w-full bg-white shadow dark:bg-neutral-900">
      <div className="mx-auto w-full px-2 sm:px-3 lg:px-4">
        <div className="flex h-16 w-full justify-between">
          <div className="flex gap-2">
            <div className="flex shrink-0 items-center">
              <Logo className="fill-black dark:fill-white" />
            </div>
          </div>
          <div className="hidden sm:ml-6 sm:flex sm:items-center">
            <ModeToggle />
            {/* Profile dropdown */}
            {/* @ts-expect-error type is correct */}
            <NavbarMenu session={session} />
          </div>
          <div className="-mr-2 flex items-center sm:hidden">
            {/* Mobile menu button */}
            <DisclosureButton className="group relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-neutral-500">
              <span className="absolute -inset-0.5" />
              <span className="sr-only">Open main menu</span>
              <Bars3Icon
                aria-hidden="true"
                className="block size-6 group-data-[open]:hidden"
              />
              <XMarkIcon
                aria-hidden="true"
                className="hidden size-6 group-data-[open]:block"
              />
            </DisclosureButton>
          </div>
        </div>
      </div>

      <DisclosurePanel className="sm:hidden">
        <div className="border-t border-gray-200 pb-3 pt-4">
          <div className="flex justify-between px-4">
            <div className="flex flex-row justify-start">
              {session?.user.image && (
                <div className="shrink-0">
                  <img
                    alt=""
                    src={session?.user.image}
                    className="size-10 rounded-full"
                  />
                </div>
              )}
              <div className="ml-3">
                <div className="text-base font-medium text-gray-800 dark:text-gray-100">
                  {session?.user.name}
                </div>
                <div className="text-sm font-medium text-gray-500 dark:text-gray-400">
                  {session?.user.email}
                </div>
              </div>
            </div>
            <div className="flex flex-row gap-4">
              <SignOutButton />
              <ModeToggle />
            </div>
          </div>
        </div>
      </DisclosurePanel>
    </Disclosure>
  );
}
