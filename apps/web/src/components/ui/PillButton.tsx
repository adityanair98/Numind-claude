import Link from "next/link";
import { type ReactNode } from "react";

interface PillButtonProps {
  children: ReactNode;
  href?: string;
  onClick?: () => void;
  variant?: "primary" | "secondary";
  size?: "sm" | "md";
  external?: boolean;
  className?: string;
  type?: "button" | "submit";
}

const variantClasses = {
  primary: "bg-brand-blue text-white hover:bg-brand-blue/90",
  secondary: "bg-brand-blue-tint text-brand-blue hover:bg-brand-blue/15",
};

const sizeClasses = {
  sm: "h-10 px-5 text-sm",
  md: "h-[54px] px-8 text-base",
};

export function PillButton({
  children,
  href,
  onClick,
  variant = "primary",
  size = "md",
  external = false,
  className = "",
  type = "button",
}: PillButtonProps) {
  const classes = `inline-flex items-center justify-center rounded-pill font-semibold cursor-pointer transition-all duration-200 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-blue active:scale-[0.98] ${variantClasses[variant]} ${sizeClasses[size]} ${className}`;

  if (href) {
    if (external) {
      return (
        <a href={href} target="_blank" rel="noopener noreferrer" className={classes}>
          {children}
        </a>
      );
    }
    return (
      <Link href={href} className={classes}>
        {children}
      </Link>
    );
  }

  return (
    <button onClick={onClick} type={type} className={classes}>
      {children}
    </button>
  );
}
