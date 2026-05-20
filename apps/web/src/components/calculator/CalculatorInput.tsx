"use client";

interface CalculatorInputProps {
  label: string;
  value: string;
  onChange: (value: string) => void;
  prefix?: string;
  suffix?: string;
  placeholder?: string;
  helper?: string;
  type?: "number" | "text";
  min?: number;
  max?: number;
  step?: number;
  id?: string;
}

export function CalculatorInput({
  label,
  value,
  onChange,
  prefix,
  suffix,
  placeholder,
  helper,
  type = "number",
  min,
  max,
  step,
  id,
}: CalculatorInputProps) {
  const inputId = id ?? label.toLowerCase().replace(/\s+/g, "-");

  return (
    <div>
      <label htmlFor={inputId} className="block text-sm font-medium text-brand-navy mb-1.5">
        {label}
      </label>
      <div className="relative flex items-center">
        {prefix && (
          <span className="absolute left-3.5 text-brand-muted text-sm pointer-events-none">
            {prefix}
          </span>
        )}
        <input
          id={inputId}
          type={type}
          inputMode="decimal"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          min={min}
          max={max}
          step={step}
          className={`w-full rounded-button border border-brand-muted/20 bg-brand-bg px-3.5 py-3 text-sm text-brand-navy placeholder:text-brand-muted/50 focus:border-brand-blue focus:outline-none focus:ring-2 focus:ring-brand-blue/20 transition-colors ${prefix ? "pl-8" : ""} ${suffix ? "pr-10" : ""}`}
        />
        {suffix && (
          <span className="absolute right-3.5 text-brand-muted text-sm pointer-events-none">
            {suffix}
          </span>
        )}
      </div>
      {helper && <p className="mt-1 text-xs text-brand-muted">{helper}</p>}
    </div>
  );
}
