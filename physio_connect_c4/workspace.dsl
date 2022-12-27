workspace "Physio integration layer project" {

    model {
        group "Physiounternehmung" {
            therapeut = person "Therapeut: in" "Person, welche Physiotherapien leitet" "therapeut"
            admin = person "Administrator: in" 
            dokumentationsSoftware = softwareSystem "Dokumentationssoftware"
            therapieFile = element "Therapie File" {
                tags "file"
            }
        }

        group "Patient" {
            patient = person "Patient: in" "Patient der jeweiligen Physio Organisation" "Patient"
            fitnessTracker = softwareSystem "Fitness Tracker"
        }

        group "Moegliche zukünftige Abhängigkeiten" {
            patientenDossier = softwareSystem "Patienten Dossier"
            versicherungsSchnittstellen = softwareSystem "Versicherungsschnittstellen"
            dataScientist = person "Data Scientist"
        }

        
        enterprise "Physio Connect" {
            physioConnect = softwareSystem "Physio Connect" {
                description "Webapp"
                tags "mainSystem"
                group "Frontend" {
                    therapeutenWebApp = container "WebApp" {
                        description "delivers browser App, maybe mobile App."
                        technology "TBD, maybe angular or react"
                    }
                    therapeutenBrowserApplication = container "browser App" {
                        tags "Web Browser"
                        description "App that is rendered by a browser"
                        technology "TBD, maybe Single Page Application"
                    }
                    therapeutenMobileApplication = container "MobileApp" {
                        tags "Mobile App"
                        technology "TBD, maybe Progressive Web App"
                    }
                }

                applicationLogic = container "Application Logic" {
                    description "Platzhalter für Applikationslogik. Kann weiter aufgeteilt oder mit anderen Containern zusammengeführt werden."
                    technology TBD
                }

                businessLogic = container "Business Logic" {
                    description "Platzhalter für Businesslogik. Kann weiter aufgeteilt oder mit anderen Containern zusammengeführt werden."
                    technology TBD
                }

                physioDb = container "Physio Datenbank" {
                    tags "Database"
                    description "Platzhalter für alle benöitgten Schemas (exklusive Benutzerdatenbank & Übungsdatenbank), wird evt aufgeteilt"
                }
            }  

            patientenApp = softwareSystem "Mobile App"
            uebungsKatalog = softwareSystem "Uebungs Katalog"
            benutzerVerwaltung = softwareSystem "Benutzer Verwaltung" "autorisierung und authentifizierung"
        }


        # relationships between people and software systems
        physioConnect -> patient "Sendet Einladung für Therapie"

        admin -> physioConnect "Administriert Personal und Uebungen"
        therapeut -> dokumentationsSoftware "Plant / Dokumentiert Therapien" 

        therapeut -> therapieFile "Editiert" 
        therapeut -> physioConnect "Plant Therapien direkt\nsendet Therapieeinladungen\nerstellt eigene Uebungen" 
        dataScientist -> physioConnect "Benutzt Daten"
        patient -> patientenApp "Registriert sich\nNimmt Therapieeinladungen an\nBenutzt App für selbstständige ausführung von Therapien"
        patient -> fitnessTracker "besitzt"
        patientenApp -> fitnessTracker "Verbindet sich mit"
        fitnessTracker ->  patientenApp "Sendet Messdaten"

        # relationships to/from software systems
        dokumentationsSoftware -> therapieFile "Exportiert"
        patientenApp -> physioConnect "Sendet Session Updates mit Messdaten"
        physioConnect -> patientenApp "Sendet Therapien, Sessions und Uebungen"
        physioConnect -> uebungsKatalog "Importiert Uebungen"
        physioConnect -> therapieFile "importiert Uebungen"
        physioConnect -> dokumentationssoftware "importiert Uebungen"
        physioConnect -> benutzerVerwaltung "Autorisiert und Authentifiziert Benutzer\n ?Erstellt neue Benutzer?"
        patientenApp -> benutzerVerwaltung "Registrierung neuer Benutzer\n Authentifiziert Benutzer"
        physioConnect -> patientenDossier "Automatischer Datenaustausch"
        physioConnect -> versicherungsSchnittstellen "teilt Trainingsdaten"
        
        # relationships to/from containers
        therapeutenMobileApplication -> therapeutenWebApp "Maybe get page, depends on technology decision"
        therapeutenBrowserApplication -> therapeutenWebApp "Maybe get page, depends on technology decision"

        therapeutenMobileApplication -> applicationLogic "Probably API calls"
        therapeutenBrowserApplication -> applicationLogic "Probably API calls"

        applicationLogic -> benutzerVerwaltung "Probably API calls"
        applicationLogic -> physioDb "TBD, z.B. JDBC / ODBC"
        applicationLogic -> uebungsKatalog "Probably API calls"
        applicationLogic -> businessLogic "TBD"

        patientenApp -> applicationLogic "Messdaten senden\nTherapiedaten Anfragen"
    }

    views {
        systemlandscape "Gesamtuebersicht" {
            include *
            autoLayout
        }

        systemlandscape "Kontextdiagram" {
            include *
            exclude dataScientist versicherungsSchnittstellen patientenDossier
            exclude dokumentationsSoftware therapieFile
            autoLayout
        }

        systemcontext physioConnect "IntegrationsSchicht" {
            include *
            animation {
                physioConnect
                patient
            }
            autoLayout
        }

        container physioConnect "Containers" {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                color #FFFFFF
                background #444444
                fontSize 22
                shape Person
            }
            element "file" {
                color #FFFFFF
                background #1168bd
                shape Folder
            }
            element "Group:Physiounternehmung" {
                color #B6862E
            }
            element "Group:Frontend" {
                color #444444
            }
            element "Group:Patient" {
                color #589FD8
            }
            element "Group:Moegliche zukünftige Abhängigkeiten" {
                color #38094E
            }
            element "Customer" {
                background #08427b
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "mainSystem" {
                background #000000
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Failover" {
                opacity 25
            }
        }
    }
}