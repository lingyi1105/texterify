import { ISearchSettings } from "../../ui/KeySearchSettings";
import { API, IFetchOptions } from "./API";
import { APIUtils } from "./APIUtils";
import { ILanguage } from "./LanguagesAPI";
import { ITranslation } from "./TranslationsAPI";

export interface IKey {
    id: string;
    type: "key";
    attributes: {
        id: string;
        project_id: string;
        name: string;
        description: string | null;
        html_enabled: boolean;
        name_editable: boolean;
        created_at: string;
        updated_at: string;
    };
    relationships: {
        translations: {
            data: { id: string; type: "translation" }[];
        };
        tags: { data: { id: string; type: "tag" }[] };
        wordpress_contents: { data: { id: string; type: "wordpress_content" }[] };
    };
}

export interface IGetKeysResponse {
    data: IKey[];
    included: (ITranslation | ILanguage)[];
    meta: { total: number };
}

export interface IPlaceholder {
    id: string;
    type: "placeholder";
    attributes: {
        id: string;
        name: string;
    };
}

export interface IGetKeyResponse {
    data: IKey;
    included: (ITranslation | ILanguage | IPlaceholder)[];
    meta: { total: number };
}

export interface IGetKeysOptions {
    search?: string;
    page?: number;
    perPage?: number;
    searchSettings?: ISearchSettings;
}

const KeysAPI = {
    getKey: async (projectId: string, keyId: string): Promise<IGetKeyResponse> => {
        return API.getRequest(`projects/${projectId}/keys/${keyId}`, true, {})
            .then(APIUtils.handleErrors)
            .catch((response) => {
                APIUtils.handleErrors(response, true);
            });
    },

    getKeys: async (
        projectId: string,
        options: IGetKeysOptions,
        fetchOptions?: IFetchOptions
    ): Promise<IGetKeysResponse> => {
        return API.getRequest(
            `projects/${projectId}/keys`,
            true,
            {
                search: (options && options.search) || undefined,
                page: options && options.page,
                per_page: options && options.perPage,
                match: options && options.searchSettings && options.searchSettings.match,
                case_sensitive: options && options.searchSettings && options.searchSettings.checkCase,
                only_untranslated: options && options.searchSettings && options.searchSettings.showOnlyUntranslated,
                only_html_enabled: options && options.searchSettings && options.searchSettings.onlyHTMLEnabled,
                only_with_overwrites:
                    options && options.searchSettings && options.searchSettings.showOnlyKeysWithOverwrites,
                changed_before: options && options.searchSettings && options.searchSettings.changedBefore,
                changed_after: options && options.searchSettings && options.searchSettings.changedAfter,
                language_ids: options && options.searchSettings && options.searchSettings.languageIds,
                export_config_ids: options && options.searchSettings && options.searchSettings.exportConfigIds
            },
            undefined,
            false,
            fetchOptions
        )
            .then(APIUtils.handleErrors)
            .catch((response) => {
                APIUtils.handleErrors(response, true);
            });
    },

    createKey: async (projectId: string, name: string, description: string, htmlEnabled: boolean): Promise<any> => {
        return API.postRequest(`projects/${projectId}/keys`, true, {
            name: name,
            description: description,
            html_enabled: htmlEnabled
        })
            .then(APIUtils.handleErrors)
            .catch((response) => {
                APIUtils.handleErrors(response, true);
            });
    },

    update: async (projectId: string, keyId: string, name: string, description: string, htmlEnabled: boolean) => {
        return API.putRequest(`projects/${projectId}/keys/${keyId}`, true, {
            name: name,
            description: description,
            html_enabled: htmlEnabled
        })
            .then(APIUtils.handleErrors)
            .catch((response) => {
                APIUtils.handleErrors(response, true);
            });
    },

    deleteKeys: async (projectId: string, keys: any) => {
        return API.deleteRequest(`projects/${projectId}/keys`, true, {
            keys: keys
        })
            .then(APIUtils.handleErrors)
            .catch((response) => {
                APIUtils.handleErrors(response, true);
            });
    },

    getActivity: async (options: { projectId: string; keyId: string }) => {
        return API.getRequest(`projects/${options.projectId}/keys/${options.keyId}/activity`, true, {})
            .then(APIUtils.handleErrors)
            .catch((response) => {
                APIUtils.handleErrors(response, true);
            });
    }
};

export { KeysAPI };
