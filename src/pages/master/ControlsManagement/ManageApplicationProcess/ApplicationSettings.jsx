import React, { useState } from "react";
import { PageHeader, CheckboxGroup, Button } from "../../../../components/master/Controls/SharedUIHelpers";
import { useNavigate } from "react-router-dom";

export default function ApplicationSettings() {
  const navigate = useNavigate();

  const [settings, setSettings] = useState({
    reApplication: true,
  });

  return (
    <>
      <PageHeader
        title="Application Settings"
        subtitle="Configure re-application and system rules"
      />

      <div className="bg-white p-8 rounded-2xl shadow-md max-w-xl space-y-6">
        <CheckboxGroup
          label="Enable Re-Application"
          checked={settings.reApplication}
          onChange={() =>
            setSettings({ reApplication: !settings.reApplication })
          }
        />

        <div className="flex justify-end">
          <Button variant="primary" onClick={() => navigate(-1)}>
            Save
          </Button>
        </div>
      </div>
    </>
  );
}
