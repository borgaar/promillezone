import "@/styles/globals.css";

import { GeistSans } from "geist/font/sans";
import { type Metadata } from "next";

import { TRPCReactProvider } from "@/trpc/react";
import { Toaster } from "../components/ui/toaster";
import Navbar from "../components/navbar/navbar";
import { ThemeProvider } from "../components/theme/theme-provider";
import { SessionProvider } from "next-auth/react";

export const metadata: Metadata = {
  title: "PromilleZone",
  description: "Kollektivets digitale system",
  icons: [{ rel: "icon", url: "/favicon.ico" }],
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${GeistSans.variable}`}>
      <body>
        <SessionProvider>
          <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
            <TRPCReactProvider>
              <Navbar />
              {children}
              <Toaster />
            </TRPCReactProvider>
          </ThemeProvider>
        </SessionProvider>
      </body>
    </html>
  );
}
